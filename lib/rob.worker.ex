defmodule Rob.Worker do

  use GenServer

## Name our server so we don't have to refer to it pid by
  @name RobWorker

## our worker will start automatically because we added the mod in the mix.exs file
## however, had we not done so, we would manualy start our server with this function.
##
## Notice, the second argument is our initial server state. We must be consistent with
## the structure of the state as we move throughout the GenServer.
##
## The last argument are arguments that we pass to the GenServrer - here we name our
## server.

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, %{calls: 0, last: ""}, args ++ [name: @name])
  end

##  notice how we impememt two functions here with the dafault args foo/1 and foo/2
  def foo(arg \\ []) do
    GenServer.call(@name, {:foo_something, arg})
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  def reset do
      GenServer.cast(@name, :reset)
  end

  def whoami do
      GenServer.call(@name, {:whoami})
  end

## the timeout as the last argument of the init will send a timeout message if the
## GenServer doesn't receive a message within the timeout period
  def init(opts) do
    {:ok, opts, 5000}
  end

## notice the second and third parameters of the call are the reply, and the state, respectively.
  def handle_call({:whoami}, _from, state) do
    {:reply, {:ok, self}, state}
  end

  def handle_call({:foo_something, foo}, from, state) do

    counter = state.calls + 1
    last = DateTime.utc_now |> DateTime.to_string

    IO.puts "Server: #{inspect self} From: #{inspect from}, passing #{inspect foo} state: #{inspect state}"

    {:reply, {:ok, counter},  %{calls: counter, last: last}}
  end

## notice, we stop the server by returning the :stop reply.
  def handle_cast(:stop, state) do
    IO.puts "stopping server"
    {:stop, :normal, state}
  end

## here we reset the state. To make resetting the state consistent, notice how we return
## the empty state as the second argument below. Had we returend [] for example, that would
## have compiled, but exccepted when we tried to run Rob.Worker.foo/0.

  def handle_cast(:reset, _state) do
    IO.puts "resetting state"
    {:noreply, %{calls: 0, last: ""}}
  end

  def handle_info(msg, state) do
    IO.puts "Received: Msg: [#{inspect msg}] State: #{inspect state}"
    {:noreply, state}
  end
end
