defmodule SpoofWeb.SpoofController do
  use SpoofWeb, :controller

  def create(conn, %{"text" => text, "command" => "/spoof", "team_domain" => team_domain, "channel_name" => "directmessage", "user_name" => user_name }) do
    spawn(SpoofWeb.SpoofController, :spoof, [text, team_domain, "@#{user_name}"])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => text, "command" => "/spoof", "team_domain" => team_domain, "channel_name" => channel_name} = params) do
    spawn(SpoofWeb.SpoofController, :spoof, [text, team_domain, channel_name])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => "", "command" => "/saito", "team_domain" => team_domain, "channel_name" => channel_name} = params) do
    text = "＊べっぴぃえぇ！！ よしぃよしぃ ベッシーおちぃつけぇ！ てぇいんさん！スメブラくでせぃ！！＊"
    spawn(SpoofWeb.SpoofController, :saito, [text, team_domain, channel_name])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => text, "command" => "/saito", "team_domain" => team_domain, "channel_name" => channel_name} = params) do
    spawn(SpoofWeb.SpoofController, :saito, [text, team_domain, channel_name])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => text, "command" => "/camel", "team_domain" => team_domain, "channel_name" => "directmessage", "user_name" => user_name}) do
    spawn(SpoofWeb.SpoofController, :camel, [text, team_domain, "@#{user_name}"])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => text, "command" => "/camel", "team_domain" => team_domain, "channel_name" => channel_name}) do
    spawn(SpoofWeb.SpoofController, :camel, [text, team_domain, channel_name])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => text, "command" => "/boy", "team_domain" => team_domain, "channel_name" => "directmessage", "user_name" => user_name}) do
    spawn(SpoofWeb.SpoofController, :boy, [text, team_domain, "@#{user_name}"])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => text, "command" => "/boy", "team_domain" => team_domain, "channel_name" => channel_name}) do
    spawn(SpoofWeb.SpoofController, :boy, [text, team_domain, channel_name])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => text, "command" => "/girl", "team_domain" => team_domain, "channel_name" => "directmessage", "user_name" => user_name}) do
    spawn(SpoofWeb.SpoofController, :girl, [text, team_domain, "@#{user_name}"])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => text, "command" => "/girl", "team_domain" => team_domain, "channel_name" => channel_name}) do
    spawn(SpoofWeb.SpoofController, :girl, [text, team_domain, channel_name])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => text, "command" => "/mentor", "team_domain" => team_domain, "channel_name" => "directmessage", "user_name" => user_name}) do
    spawn(SpoofWeb.SpoofController, :mentor, [text, team_domain, "@#{user_name}"])

    send_resp(conn, 200, "")
  end

  def create(conn, %{"text" => text, "command" => "/mentor", "team_domain" => team_domain, "channel_name" => channel_name}) do
    spawn(SpoofWeb.SpoofController, :mentor, [text, team_domain, channel_name])

    send_resp(conn, 200, "")
  end

  def spoof(text, team_domain, channel_name) do
    [head | tail] = String.split(text, " ")
    msg = Enum.join(tail, " ")
    username = String.split(head, "@") |> Enum.at(1)
    domain = domain(team_domain)
    member = Enum.find(members(domain), &(&1["name"] == username))

    post(webhook_url(domain), msg, username(member["profile"]["display_name"], member["profile"]["real_name"]), member["profile"]["image_72"], channel_name)
  end

  def saito(text, team_domain, channel_name) do
    domain(team_domain)
      |> webhook_url
      |> post(text, "ハナミトリ夫", "https://i.imgur.com/q58ZDDo.png", channel_name)
  end

  def camel(text, team_domain, channel_name) do
    domain(team_domain)
      |> webhook_url
      |> post(text, "camel", "https://emoji.slack-edge.com/T1PM95NMT/challecara-camel/884b714ec87aa85b.png", channel_name)
  end

  def boy(text, team_domain, channel_name) do
    domain(team_domain)
      |> webhook_url
      |> post(text, "boy", "https://emoji.slack-edge.com/T1PM95NMT/challecara-boy/223a09c8f4532f94.png", channel_name)
  end

  def girl(text, team_domain, channel_name) do
    domain(team_domain)
      |> webhook_url
      |> post(text, "girl", "https://emoji.slack-edge.com/T1PM95NMT/challecara-girl/76bb1c3b336f522e.png", channel_name)
  end

  def mentor(text, team_domain, channel_name) do
    domain(team_domain)
      |> webhook_url
      |> post(text, "mentor", "https://emoji.slack-edge.com/T1PM95NMT/challecara-mentor/be961fd29d7bacdd.png", channel_name)
  end

  defp post(url, text, username, icon_url, channel_name) do
    body = %{
              text: text,
              username: username,
              icon_url: icon_url,
              link_names: 1,
              channel: channel_name
            } |> Poison.encode!()

    headers = [{"Content-type", "application/json"}]
    HTTPoison.post!(url, body, headers)
  end

  defp members(domain) do
    {:ok, %{ body: body }} = users_list_url(domain) |> HTTPoison.get
    %{"members" => members} = Poison.decode!(body)
    members
  end

  defp domain(team_domain) do
    team_domain
      |> String.upcase
      |> String.replace("-", "_")
  end

  defp webhook_url(domain) do
    System.get_env("SLACK_#{domain}_WEBHOOK_URL")
  end

  defp users_list_url(domain) do
    "https://slack.com/api/users.list?token=#{System.get_env("SLACK_#{domain}_TOKEN")}"
  end

  defp username(display_name, real_name) when byte_size(display_name) == 0 do
    real_name
  end

  defp username(display_name, real_name), do: display_name
end