# Harmony

This is the repository of the backend of discord clone application to demonstrate my understanding of the core features of Elixir.  
The backend will serve responses to requests from web/mobile app client side to enable its features.

## Running server application
In the directory of this project:
- run `iex -S mix`
- run the process `spawn(Harmony.HttpServer, :start, [4000])` where `4000` is the port number the server will be using. Alternatively choose your own preferred port. (Note: port has to be > 1023, as for most systems these ports are occupied.
- access the server resources in the browser with the following address `localhost:4000/(slugs)` (or alternatively your preferred port number that you run the server on.

## Available (slugs):

### localhost:4000/servers
> list all the available chat server based on the data from the file `servers.csv` and display the data as html.

### localhost:4000/servers/id
> id can be from 1..4, each id have different server. Returns a page where you can send a message to entities listening for messages in the server.

### localhost:4000/api/servers
> returns list of all servers data as JSON for client side mobile application.

### localhost:4000/info/about
> shows the overall information about the repository of this server.

### localhost:4000/info/register
> shows the html form to send a post request to create a new server. Creation of the new server itself is **not yet implemented**.

## Language Versions
> This repository is made using `Elixir 1.12.0-dev` and its required `Erlang/OTP 23`.

