# frozen_string_literal: true

module GrommunioAdminApi
  module Api
    # Mailing lists under /domains/{domainID}/mlists.
    class MailingLists < Base
      # PATCH /domains/{domainID}/mlists/{ID} - changes who may send to the
      # list address. Deliberately limited to listPrivilege: it is the only
      # field a caller needs to change after an LDAP import, and a later LDAP
      # downsync keeps it.
      #
      # @param id [Integer] the mailing list ID (Resources::MailingList#id),
      #   not the ID of the list's users row
      # @param list_privilege [Integer] one of Resources::MailingList::PRIVILEGES
      # @return [Resources::MailingList]
      def update(domain_id:, id:, list_privilege:)
        unless Resources::MailingList::PRIVILEGES.include?(list_privilege)
          raise ArgumentError, "list_privilege must be one of #{Resources::MailingList::PRIVILEGES.inspect}"
        end

        body = connection.request(:patch, "/domains/#{domain_id}/mlists/#{id}",
                                  json: { listPrivilege: list_privilege })
        Resources::MailingList.new(body)
      end
    end
  end
end
