// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// Bring in Phoenix channels client library:
import { Socket } from "phoenix";

// And connect to the path in "lib/aikokusha_web/endpoint.ex". We pass the
// token for authentication. Read below how it should be used.
let socket = new Socket("/socket", { params: { token: window.userToken } });

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/aikokusha_web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/aikokusha_web/templates/layout/app.html.heex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/aikokusha_web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1_209_600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect();

// // Now that you are connected, you can join channels with a topic.
// // Let's assume you have a channel with a topic named `room` and the
// // subtopic is its id - in this case 42:
// let channel = socket.channel("room:42", {})
// channel.join()
//   .receive("ok", resp => { console.log("Joined successfully", resp) })
//   .receive("error", resp => { console.log("Unable to join", resp) })

let channel = socket.channel("room:lobby", {});

if (window.location.href.includes("chat")) {
  // List of messages.
  const ul = document.getElementById("msg-list");
  // Name of message sender.
  const name = document.getElementById("name");
  // Message input field.
  const msg = document.getElementById("msg");
  // Send button.
  const send = document.getElementById("send");

  channel
    .join()
    .receive("ok", (resp) => {
      console.log("Joined successfully", resp);
    })
    .receive("error", (resp) => {
      console.log("Unable to join", resp);
    });

  // Listening to 'shout' events.
  channel.on("shout", (payload) => {
    render_message(payload);
  });

  // Send the message to the server on "shout" channel
  const sendMessage = () => {
    channel.push("shout", {
      // Get value of "name" of person sending the message. Set guest as default
      name: name.value || "爱国者",
      // Get message text (value) from msg input field.
      message: msg.value,
      // Date + time of when the message was sent.
      inserted_at: new Date(),
    });

    // Reset the message input field for next message.
    msg.value = "";
    // Scroll to the end of the page on send.
    window.scrollTo(0, document.documentElement.scrollHeight);
  };

  // Render the message with Tailwind styles
  const render_message = (payload) => {
    // Create new list item DOM element.
    const li = document.createElement("li");

    // Message HTML with Tailwind CSS Classes for layout/style.
    li.innerHTML = `
  <div class="flex flex-row w-[95%] mx-2 border-b-[1px] border-slate-300 py-2 hover:bg-gray-300">
    <div class="text-left w-1/5 font-semibold text-red-800 break-words">
      ${payload.name}
      <div class="text-xs mr-1">
        <span class="font-thin">${formatDate(payload.inserted_at)}</span> 
        <span>${formatTime(payload.inserted_at)}</span>
      </div>
    </div>
    <div class="flex w-3/5 mx-1 grow text-red-800">
      ${payload.message}
    </div>
  </div>
  `;
    // Append to list.
    ul.appendChild(li);
  };

  // Listen for the [Enter] keypress event to send a message.
  msg.addEventListener("keypress", (event) => {
    if (event.code === "Enter" && msg.value.length > 0) {
      // don't sent empty msg.
      sendMessage();
    }
  });

  // On "Send" button press.
  send.addEventListener("click", (_event) => {
    if (msg.value.length > 0) {
      // don't sent empty msg.
      sendMessage();
    }
  });

  // Date formatting.
  const formatDate = (datetime) => {
    const m = new Date(datetime);
    return (
      m.getUTCFullYear() +
      "/" +
      ("0" + (m.getUTCMonth() + 1)).slice(-2) +
      "/" +
      ("0" + m.getUTCDate()).slice(-2)
    );
  };

  // Time formatting.
  const formatTime = (datetime) => {
    const m = new Date(datetime);
    return (
      ("0" + m.getUTCHours()).slice(-2) +
      ":" +
      ("0" + m.getUTCMinutes()).slice(-2) +
      ":" +
      ("0" + m.getUTCSeconds()).slice(-2)
    );
  };
}

export default socket;
