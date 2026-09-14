# frozen_string_literal: true

RSpec.describe GrommunioAdminApi::Api::Domains do
  before { stub_login }

  let(:client) { build_client }
  let(:domain_payload) do
    {
      "ID" => 12,
      "orgID" => 12,
      "domainname" => "asc-test.ch",
      "displayname" => "ASC Test",
      "domainStatus" => 0,
      "maxUser" => 25,
      "activeUsers" => 7,
      "inactiveUsers" => 1,
      "virtualUsers" => 2,
      "chat" => false,
      "homeserver" => nil,
      "newField" => "kept"
    }
  end
  # shaped after the domainDnsCheck schema: every value nullable, nil meaning
  # unresolvable; only the records of a well set-up domain carry values
  let(:dns_check_payload) do
    {
      "localIp" => "10.0.0.5",
      "externalIp" => "203.0.113.10",
      "mxRecords" => { "internalDNS" => nil, "externalDNS" => "203.0.113.10",
                       "mxDomain" => "mail.example.ch.", "reverseLookup" => "mail.example.ch." },
      "autodiscover" => { "internalDNS" => nil, "externalDNS" => "203.0.113.10" },
      "autodiscoverSRV" => { "internalDNS" => nil, "externalDNS" => "0 0 443 mail.example.ch.",
                             "ip" => "203.0.113.10" },
      "autoconfig" => { "internalDNS" => nil, "externalDNS" => nil },
      "txt" => { "internalDNS" => nil, "externalDNS" => '"v=spf1 mx -all"' },
      "dkim" => { "internalDNS" => nil, "externalDNS" => nil },
      "dmarc" => { "internalDNS" => nil, "externalDNS" => '"v=DMARC1; p=quarantine"' },
      "caldavTXT" => { "internalDNS" => nil, "externalDNS" => nil },
      "carddavTXT" => { "internalDNS" => nil, "externalDNS" => nil },
      "submissionSRV" => { "internalDNS" => nil, "externalDNS" => nil },
      "imapSRV" => { "internalDNS" => nil, "externalDNS" => nil },
      "imapsSRV" => { "internalDNS" => nil, "externalDNS" => nil },
      "pop3SRV" => { "internalDNS" => nil, "externalDNS" => nil },
      "pop3sSRV" => { "internalDNS" => nil, "externalDNS" => nil },
      "caldavSRV" => { "internalDNS" => nil, "externalDNS" => nil },
      "caldavsSRV" => { "internalDNS" => nil, "externalDNS" => nil },
      "carddavSRV" => { "internalDNS" => nil, "externalDNS" => nil },
      "carddavsSRV" => { "internalDNS" => nil, "externalDNS" => nil },
      "newField" => "kept"
    }
  end

  it "lists domains with comma-encoded array filters" do
    list = stub_get("/system/domains", { "count" => 1, "data" => [domain_payload] },
                    query: { "limit" => "50", "offset" => "0", "orgID" => "12,13", "domainStatus" => "0,1" })

    result = client.domains.list(limit: 50, offset: 0, organization_ids: [12, 13], statuses: [0, 1])

    expect(list).to have_been_requested.once
    expect(result.first.domainname).to eq("asc-test.ch")
  end

  it "gets one domain with all declared fields and raw preservation" do
    stub_get("/system/domains/12", domain_payload)

    domain = client.domains.get(domain_id: 12)

    expect(domain).to have_attributes(
      id: 12, organization_id: 12, domainname: "asc-test.ch", displayname: "ASC Test",
      domain_status: 0, max_user: 25, active_users: 7, inactive_users: 1,
      virtual_users: 2, chat: false, homeserver: nil
    )
    expect(domain["newField"]).to eq("kept")
  end

  it "paginates lazily through all domains" do
    stub_get("/system/domains", { "count" => 3, "data" => [{ "ID" => 1 }, { "ID" => 2 }] },
             query: { "limit" => "2", "offset" => "0" })
    stub_get("/system/domains", { "count" => 3, "data" => [{ "ID" => 3 }] },
             query: { "limit" => "2", "offset" => "2" })

    expect(client.domains.all(page_size: 2).map(&:id).to_a).to eq([1, 2, 3])
  end

  it "forwards the list filters to every page request" do
    query = { "orgID" => "12,13", "domainStatus" => "0" }
    page1 = stub_get("/system/domains", { "count" => 3, "data" => [{ "ID" => 1 }, { "ID" => 2 }] },
                     query: query.merge("limit" => "2", "offset" => "0"))
    page2 = stub_get("/system/domains", { "count" => 3, "data" => [{ "ID" => 3 }] },
                     query: query.merge("limit" => "2", "offset" => "2"))

    domains = client.domains.all(organization_ids: [12, 13], statuses: [0], page_size: 2).to_a

    expect(domains.map(&:id)).to eq([1, 2, 3])
    expect(page1).to have_been_requested.once
    expect(page2).to have_been_requested.once
  end

  it "runs the DNS check of one domain with the top-level fields and raw preservation" do
    stub = stub_get("/domains/12/dnsCheck", dns_check_payload)

    check = client.domains.dns_check(domain_id: 12)

    expect(stub).to have_been_requested.once
    expect(check).to be_a(GrommunioAdminApi::Resources::DnsCheck)
    expect(check).to have_attributes(local_ip: "10.0.0.5", external_ip: "203.0.113.10")
    expect(check["newField"]).to eq("kept")
  end

  it "wraps every nested record of the DNS check as a lookup" do
    stub_get("/domains/12/dnsCheck", dns_check_payload)

    check = client.domains.dns_check(domain_id: 12)

    expect(check.mx_records).to have_attributes(internal_dns: nil, external_dns: "203.0.113.10",
                                                mx_domain: "mail.example.ch.", reverse_lookup: "mail.example.ch.")
    expect(check.autodiscover_srv.ip).to eq("203.0.113.10")
    expect(check.txt.external_dns).to eq('"v=spf1 mx -all"')
    expect(check.pop3_srv.external_dns).to be_nil
  end

  it "runs the DNS check in read_only mode without a mutation guard" do
    stub_get("/domains/12/dnsCheck", dns_check_payload)

    expect { build_client(mode: :read_only).domains.dns_check(domain_id: 12) }.not_to raise_error
  end
end
