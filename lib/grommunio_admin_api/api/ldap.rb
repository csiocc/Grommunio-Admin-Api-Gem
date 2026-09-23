# frozen_string_literal: true

module GrommunioAdminApi
  module Api
    # LDAP candidate search, targeted import, and the domain-wide downsync.
    class Ldap < Base
      MIN_QUERY_LENGTH = 3

      # GET /domains/ldap/search
      #
      # @return [List<Resources::LdapCandidate>]
      def search(query:, domain_id: nil, organization_id: nil, show_all: nil, limit: nil)
        if query.to_s.gsub(/\s/, "").length < MIN_QUERY_LENGTH
          raise ArgumentError, "query must contain at least three non-whitespace characters"
        end

        params = { query: query, domain: domain_id, organization: organization_id,
                   showAll: show_all, limit: limit }
        body = connection.request(:get, "/domains/ldap/search", query: params)
        List.new(body, resource_class: Resources::LdapCandidate)
      end

      # POST /domains/ldap/importUser — first targeted import of one LDAP user.
      #
      # Despite the name, upstream imports whatever the LDAP object is: a group
      # becomes a mailing list with its members synced once, at creation. The
      # answer is then the list's own users row, so the list ID is
      # User#mailing_list_id, not User#id (verified live, API 1.21.0).
      #
      # @return [Resources::User] when the server returns user data,
      #   [Resource] for a message-only response
      def import_user(ldap_object_id:, domain_id: nil, organization_id: nil, language: nil, force: nil)
        params = { ID: ldap_object_id, domain: domain_id, organization: organization_id,
                   lang: language, force: force }
        body = connection.request(:post, "/domains/ldap/importUser", query: params)
        Resources.wrap_user_or_generic(body)
      end

      # POST /domains/{domainID}/ldap/downsync - refreshes every LDAP-linked
      # object of the domain and then syncs the members of every LDAP group of
      # the domain's organization. It is the only HTTP path that updates the
      # members of an existing mailing list.
      #
      # Never sends import=true: that would import every new LDAP candidate as
      # a mailbox, which is not a sync, and this route is allowed in sync_only
      # mode. For the same reason there is no language parameter, it only
      # applies to newly created objects.
      #
      # @return [Resources::LdapSync] running? while the background task has
      #   not finished within the server's wait time (202)
      def downsync_domain(domain_id:)
        body = connection.request(:post, "/domains/#{domain_id}/ldap/downsync")
        Resources::LdapSync.new(body)
      end
    end
  end
end
