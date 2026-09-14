# frozen_string_literal: true

RSpec.describe GrommunioAdminApi::Resources::DnsCheck do
  it "wraps a missing or null record as an empty lookup instead of nil" do
    check = described_class.new("mxRecords" => nil)

    expect(check.mx_records).to be_a(described_class::Lookup)
    expect(check.mx_records.external_dns).to be_nil
    expect(check.dkim).to be_a(described_class::Lookup)
    expect(check.dkim.internal_dns).to be_nil
  end

  it "exposes the extra MX and autodiscover SRV fields only where they arrive" do
    check = described_class.new(
      "mxRecords" => { "mxDomain" => "mail.example.ch.", "reverseLookup" => "mail.example.ch." },
      "autodiscoverSRV" => { "ip" => "203.0.113.10" }
    )

    expect(check.mx_records.mx_domain).to eq("mail.example.ch.")
    expect(check.mx_records.reverse_lookup).to eq("mail.example.ch.")
    expect(check.autodiscover_srv.ip).to eq("203.0.113.10")
    expect(check.autodiscover.ip).to be_nil
  end

  it "keeps the upstream spelling for the SPF record" do
    check = described_class.new("txt" => { "externalDNS" => '"v=spf1 mx -all"' })

    expect(check.txt.external_dns).to eq('"v=spf1 mx -all"')
    expect(check).not_to respond_to(:spf)
  end

  it "declares one reader per nested upstream key" do
    expect(described_class::LOOKUP_KEYS.values).to match_array(
      %w[mxRecords autodiscover autodiscoverSRV autoconfig txt dkim dmarc caldavTXT carddavTXT
         submissionSRV imapSRV imapsSRV pop3SRV pop3sSRV caldavSRV caldavsSRV carddavSRV carddavsSRV]
    )
  end
end
