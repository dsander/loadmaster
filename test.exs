require Logger

server = %{
  baseUrl: "https://192.168.99.100:2376",
  ssl_options: [
    {:certfile, '/Users/dominik/.docker/machine/certs/cert.pem'},
    {:keyfile, '/Users/dominik/.docker/machine/certs/key.pem'},
  ],
  insecure: true
}

{:ok, conn} = Docker.start_link server
IO.inspect Docker.info conn
