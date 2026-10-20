# frozen_string_literal: true

module GrommunioAdminApi
  module Resources
    # The instance license from GET /system/license.
    #
    # Without a valid certificate (none installed, unreadable or expired) the
    # server silently falls back to a built-in Community license: 5 users,
    # notAfter in year 9999 and certificate nil. The real expiry of an expired
    # certificate is not reported anymore, so certificate is the only field
    # that tells a valid license apart from the fallback.
    #
    # currentUsers counts the users taking a seat and is nil when the server
    # failed to count them. Dates arrive as "YYYY-MM-DD HH:MM:SS" in UTC.
    class License < Resource
      field :product
      field :max_users, key: "maxUsers"
      field :current_users, key: "currentUsers"
      field :not_before, key: "notBefore"
      field :not_after, key: "notAfter"
      field :certificate
    end
  end
end
