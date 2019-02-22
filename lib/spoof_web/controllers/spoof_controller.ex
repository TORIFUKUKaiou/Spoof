defmodule SpoofWeb.SpoofController do
  use SpoofWeb, :controller

  def create(conn, %{"text" => text, "command" => "/spoof", "team_domain" => team_domain, "channel_name" => channel_name} = params) do
    [head | tail] = String.split(text, " ")
    msg = Enum.join(tail, " ")
    username = String.split(head, "@") |> Enum.at(1)
    domain = domain(team_domain)
    member = Enum.find(members(domain), &(&1["name"] == username))

    post(webhook_url(domain), msg, username, member["profile"]["image_72"], channel_name)

    json conn, nil
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
end