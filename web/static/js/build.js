let Build = {
  init(socket) {
    if(!$("[data-build-id]").length) { return }
    socket.connect()
    this.joinBuild($("[data-build-id]").data('buildId'), socket)
  },

  joinBuild(id, socket) {
    let channel = socket.channel("build:" + id, {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    channel.on("output", ({job_id, step, row}) => {
      $(`.panel-group[data-job-id=${job_id}] [data-step=${step}] pre`).append(row + "\n")
      $(`.panel-group[data-job-id=${job_id}] [data-step!=${step}] .panel-collapse`).collapse('hide')
      $(`.panel-group[data-job-id=${job_id}] [data-step=${step}]  .panel-collapse`).collapse('show')
    })

    channel.on("update_state", ({job_id, step, value}) => {
      if(value == "running") {
        value = "warning"
      } else if(value == "error") {
        value = "danger"
      }
      if(value == "success") {
        $(`.panel-group[data-job-id=${job_id}] [data-step=${step}]  .panel-collapse`).collapse('hide')
      }
      $(`.panel-group[data-job-id=${job_id}] [data-step=${step}]`).removeClass('panel-warning').removeClass('panel-default').addClass(`panel-${value}`)
    })
  }
}
export default Build
