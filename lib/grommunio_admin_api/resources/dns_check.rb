# frozen_string_literal: true

module GrommunioAdminApi
  module Resources
    # The raw result of GET /domains/{domainID}/dnsCheck.
    #
    # The server resolves every record twice, through its own resolver
    # (internalDNS) and through the configured external resolvers
    # (externalDNS), and evaluates nothing: nil means the lookup failed or
    # returned no record. Field names follow the upstream keys, so "txt" stays
    # "txt" although the server only keeps TXT records starting with "v=spf1".
    class DnsCheck < Resource
      # One record from the two resolver perspectives. mx_domain and
      # reverse_lookup only arrive on mx_records, ip only on autodiscover_srv;
      # the readers return nil everywhere else.
      class Lookup < Resource
        field :internal_dns, key: "internalDNS"
        field :external_dns, key: "externalDNS"
        field :mx_domain, key: "mxDomain"
        field :reverse_lookup, key: "reverseLookup"
        field :ip
      end

      LOOKUP_KEYS = {
        mx_records: "mxRecords",
        autodiscover: "autodiscover",
        autodiscover_srv: "autodiscoverSRV",
        autoconfig: "autoconfig",
        txt: "txt",
        dkim: "dkim",
        dmarc: "dmarc",
        caldav_txt: "caldavTXT",
        carddav_txt: "carddavTXT",
        submission_srv: "submissionSRV",
        imap_srv: "imapSRV",
        imaps_srv: "imapsSRV",
        pop3_srv: "pop3SRV",
        pop3s_srv: "pop3sSRV",
        caldav_srv: "caldavSRV",
        caldavs_srv: "caldavsSRV",
        carddav_srv: "carddavSRV",
        carddavs_srv: "carddavsSRV"
      }.freeze

      field :local_ip, key: "localIp"
      field :external_ip, key: "externalIp"

      # A missing or null record becomes an empty Lookup, so callers never
      # branch on nil before reading a perspective.
      LOOKUP_KEYS.each do |name, key|
        define_method(name) { Lookup.new(@raw[key]) }
      end
    end
  end
end
