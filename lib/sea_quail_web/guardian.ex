defmodule SeaQuailWeb.Guardian do
  use Guardian, otp_app: :sea_quail

  def subject_for_token(user, _claims), do: {:ok, to_string(user.id)}

  def resource_from_claims(claims) do
    # Here we'll look up our resource from the claims, the subject can be
    # found in the `"sub"` key. In `above subject_for_token/2` we returned
    # the resource id so here we'll rely on that to look it up.
    user_id = claims["sub"]
    resource = SeaQuail.Accounts.get_user!(user_id)
    {:ok, resource}
  end
end
  