#!/usr/bin/env ruby

require "json"

ROOT = File.expand_path("../..", __dir__)
DATA_PATH = File.join(ROOT, "data", "zenodo.json")
FIXTURE_ID = ENV.fetch("LIFECYCLE_FIXTURE_ID")
POST_PREFIX = "lifecycle-#{FIXTURE_ID}"
REQUIRE_DOI = ARGV.include?("--require-doi")

store = File.exist?(DATA_PATH) ? JSON.parse(File.read(DATA_PATH)) : {}
errors = []

%w[submitted withdrawn draft].each do |suffix|
  post_id = "#{POST_PREFIX}-#{suffix}"
  errors << "#{post_id}: non-accepted fixture should not have Zenodo metadata" if store.key?(post_id)
end

accepted_id = "#{POST_PREFIX}-accepted"
accepted = store[accepted_id]

if REQUIRE_DOI
  if accepted.nil?
    errors << "#{accepted_id}: accepted fixture is missing Zenodo metadata"
  else
    errors << "#{accepted_id}: current_revision must be 3" unless accepted["current_revision"].to_i == 3
    errors << "#{accepted_id}: current_doi is missing" if accepted["current_doi"].to_s.empty?
    revisions = accepted["revisions"] || {}
    %w[1 2 3].each do |version|
      revision = revisions[version] || {}
      errors << "#{accepted_id}: revision #{version} DOI is missing" if revision["doi"].to_s.empty?
      errors << "#{accepted_id}: revision #{version} Zenodo URL is missing" if revision["zenodo_url"].to_s.empty?
    end
  end
end

if errors.any?
  warn "Lifecycle fixture validation failed:"
  errors.each { |error| warn "  - #{error}" }
  exit 1
end

puts "Lifecycle fixture validation passed."
