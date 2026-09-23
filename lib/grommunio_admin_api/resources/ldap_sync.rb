# frozen_string_literal: true

module GrommunioAdminApi
  module Resources
    # The answer of POST /domains/{domainID}/ldap/downsync.
    #
    # The endpoint starts a background task and waits briefly for it. A task
    # that is still running answers 202 with a task_id; a finished one answers
    # 200 with per-object results in data and no task_id.
    class LdapSync < Resource
      field :message
      field :task_id, key: "taskID"
      field :data

      def running?
        !task_id.nil?
      end
    end
  end
end
