import Queue from "./queue"

let Build = {
  init(socket) {
    socket.connect()
    this.joinBuild(socket)
    this.queue = new Queue()
  },

  joinBuild(socket) {
    let channel = socket.channel("builds", {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    channel.on("output", (message) => {
      this.handleMessage("output", message)
    })

    channel.on("update_state", (message) => {
      this.handleMessage("update_state", message)
    })
  },

  handleMessage(channel, message) {
    if($(`[data-job-id=${message.job_id}]`).length > 0) {
      this.emptyQueue(channel, message)
      this.render(channel, message)
    } else {
      this.queue.enqueue(channel, message)
    }
  },

  emptyQueue(channel, {job_id, step}) {
    var value;
    while(value = this.queue.shift(channel, {job_id: job_id, step: step})) {
      this.render(channel, {job_id: job_id, step: step, value: value})
    }
  },

  render(channel, message) {
    if(channel == 'output') {
      this.renderOutput(message)
    } else if(channel == 'update_state') {
      this.renderUpdateState(message)
    }
  },

  renderOutput({job_id, step, value}) {
    $(`.panel-group[data-job-id=${job_id}] [data-step=${step}] pre`).append(value + "\n")
    $(`.panel-group[data-job-id=${job_id}] [data-step!=${step}] .panel-collapse`).collapse('hide')
    $(`.panel-group[data-job-id=${job_id}] [data-step=${step}]  .panel-collapse`).collapse('show')
  },

  renderUpdateState({job_id, step, value}) {
    if(value == "running") {
      value = "warning"
    } else if(value == "error") {
      value = "danger"
    }
    if(value == "success") {
      $(`.panel-group[data-job-id=${job_id}] [data-step=${step}]  .panel-collapse`).collapse('hide')
    }
    $(`.panel-group[data-job-id=${job_id}] [data-step=${step}]`).removeClass('panel-warning').removeClass('panel-default').addClass(`panel-${value}`)
  }
}
export default Build
