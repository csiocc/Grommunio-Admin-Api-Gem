# frozen_string_literal: true

module GrommunioAdminApi
  module Resources
    # One mailing list from /domains/{domainID}/mlists.
    #
    # id is the mailing list ID that /domains/{domainID}/mlists/{ID} expects;
    # user_id is the ID of the list's own row under /domains/{domainID}/users.
    class MailingList < Resource
      TYPE_NORMAL = 0
      TYPE_DOMAIN = 2

      # Who may send to the list address. PRIVILEGE_SPECIFIED with an empty
      # specifieds list lets nobody send.
      PRIVILEGE_ALL = 0
      PRIVILEGE_INTERNAL = 1
      PRIVILEGE_DOMAIN = 2
      PRIVILEGE_SPECIFIED = 3
      PRIVILEGE_OUTGOING = 4
      PRIVILEGES = [
        PRIVILEGE_ALL, PRIVILEGE_INTERNAL, PRIVILEGE_DOMAIN, PRIVILEGE_SPECIFIED, PRIVILEGE_OUTGOING
      ].freeze

      field :id, key: "ID"
      field :listname
      field :display_name, key: "displayname"
      field :list_type, key: "listType"
      field :list_privilege, key: "listPrivilege"
      field :associations
      field :specifieds
      field :domain_id, key: "domainID"
      field :user_id, key: "user"
    end
  end
end
