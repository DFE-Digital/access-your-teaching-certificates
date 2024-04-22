module Qualifications
  class QualificationsController < QualificationsInterfaceController
    def show
      begin
        client = QualificationsApi::Client.new(token: session[user_token_session_key])
        @teacher = client.teacher
      rescue QualificationsApi::InvalidTokenError
        redirect_to qualifications_sign_out_path and return
      rescue QualificationsApi::ForbiddenError => e
        send_additional_detail_to_sentry(e)
        redirect_to qualifications_sign_out_path and return
      end

      @user = current_user
    end
    private

    def extract_payload(token)
      _header, encoded_payload, _signature = token.split('.')
      payload = Base64.urlsafe_decode64(encoded_payload)
      JSON.parse payload
    end

    def send_additional_detail_to_sentry(exception)
      api_token_payload = extract_payload(session[user_token_session_key])
      Sentry.with_scope do |scope|
        scope.set_user(id: current_user.id)
        scope.set_context(
          'Authentication session',
          {
            trn: current_user.trn,
            auth_uuid: current_user.auth_uuid,
            api_tkn_expiry: Time.zone.at(session[user_token_expiry_session_key]),
            "payload.trn" => api_token_payload["trn"],
            "payload.scope" => api_token_payload["scope"],
            "payload.identity_exp" => api_token_payload["exp"],
            "payload.identity_exp_parsed" => Time.zone.at(api_token_payload["exp"]),
          }
        )
        Sentry.capture_exception(exception)
      end
    end
  end
end
