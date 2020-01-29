defmodule AccountingWeb.PageView do
  use AccountingWeb, :view

  def render("index.json", %{domains: domains, status: status}) do
    %{domains: domains, status: status}
  end

end
