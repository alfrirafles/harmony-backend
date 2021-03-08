defmodule Harmony.Timezone do
  defstruct date: nil, time: nil

  def utc_plus_7 do
    utc = %Harmony.Timezone{date: Date.utc_today, time: Time.utc_now}
    %{utc | date: Date.add(utc.date, 1), time: Time.add(utc.time, 25200, :second)}
  end
end