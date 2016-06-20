class Queue {
  constructor() {
    this.queue = {}
  }

  enqueue(channel, message) {
    var key = this.key(channel, message)
    this.queue[key] = this.queue[key] || []
    this.queue[key].push(message.value)
  }

  shift(channel, message) {
    var key = this.key(channel, message)
    if(!this.queue[key]) return undefined
    return this.queue[key].shift()
  }

  key(channel, {job_id, step}) {
    return `${channel}${job_id}${step}`
  }
}

export default Queue
