const sanitizeText = msg => {
  let div = document.createElement("div")
  div.appendChild(document.createTextNode(msg))

  return div.innerHTML
}

const createDiv = msg => {
  let div = document.createElement("div")

  div.innerHTML = `
    <span>
      <strong>anonymous</strong>: ${sanitizeText(msg)}
    </span>
  `

  return div
}

const renderChat = (msgContainer, { body }) => {
  msgContainer.appendChild(createDiv(body))
  msgContainer.scrollTop = msgContainer.scrollHeight
}

const onReady = roomChannel => roomChannel
  .join()
  .receive("ok", res => console.log("joined room channel", res))
  .receive("error", reason => console.error("failed to join", reason))

const postMessage = (roomChannel, msgInput) => roomChannel
  .push("new_chat", { body: msgInput.value })
  .receive("error", console.error)

const handleMessages = (roomChannel, msgContainer) => roomChannel
  .on("new_chat", msg => renderChat(msgContainer, msg))

const Room = (socket, el) => {
  const roomId = el.getAttribute("data-id")
  const postButton = document.getElementById("msg-submit")
  const msgInput = document.getElementById("msg-input")
  const msgContainer = document.getElementById("msg-container")

  const roomChannel = socket.channel("rooms:" + roomId)
  console.log(`element: ${el}, roomId: ${roomId}`)

  socket.connect()
  onReady(roomChannel)
  handleMessages(roomChannel, msgContainer)
  postButton.addEventListener("click", () => {
    postMessage(roomChannel, msgInput)
    msgInput.value = ""
  })
}

export default Room
