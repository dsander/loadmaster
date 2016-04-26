// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"

window.joinRepository = function(name) {
  let channel = socket.channel("repository:" + name, {})
  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  channel.on("build", payload => {
    console.log(payload)
    if(payload.body == "") return
    $("#status").append(payload.body + "<br>")
  })
}


window.joinBuild = function(id) {
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
