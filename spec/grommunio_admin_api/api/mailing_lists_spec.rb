# frozen_string_literal: true

RSpec.describe GrommunioAdminApi::Api::MailingLists do
  describe "#update" do
    let(:client) { build_client(mode: :full_write) }
    let(:list_body) do
      { "ID" => 12, "listname" => "ccc_gro_board@example.ch", "listType" => 0, "listPrivilege" => 3,
        "associations" => ["kim@example.ch"], "specifieds" => [], "domainID" => 4, "user" => 62 }
    end

    it "patches only listPrivilege and returns the updated mailing list" do
      stub_login
      patch = stub_write(:patch, "/domains/4/mlists/12", json: { listPrivilege: 3 }, body: list_body)

      list = client.mailing_lists.update(
        domain_id: 4, id: 12, list_privilege: GrommunioAdminApi::Resources::MailingList::PRIVILEGE_SPECIFIED
      )

      expect(patch).to have_been_requested.once
      expect(list).to be_a(GrommunioAdminApi::Resources::MailingList)
      expect(list).to have_attributes(id: 12, list_privilege: 3, specifieds: [])
    end

    it "rejects an unknown privilege before any socket access" do
      expect { client.mailing_lists.update(domain_id: 4, id: 12, list_privilege: 5) }
        .to raise_error(ArgumentError, /list_privilege/)

      expect_no_http_requests
    end

    it "is not a sync operation" do
      expect do
        build_client(mode: :sync_only).mailing_lists.update(domain_id: 4, id: 12, list_privilege: 3)
      end.to raise_error(GrommunioAdminApi::SyncOperationNotAllowedError)

      expect_no_http_requests
    end
  end
end
