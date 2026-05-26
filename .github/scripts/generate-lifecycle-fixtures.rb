#!/usr/bin/env ruby

require "fileutils"
require "yaml"

ROOT = File.expand_path("../..", __dir__)
RUN_ID = ENV.fetch("LIFECYCLE_FIXTURE_ID", ENV.fetch("GITHUB_RUN_ID", Time.now.utc.strftime("%Y%m%d%H%M%S")))
POST_PREFIX = "lifecycle-#{RUN_ID}"
REVISION = ENV.fetch("ACCEPTED_REVISION", "1").to_i
TODAY = ENV.fetch("LIFECYCLE_FIXTURE_DATE", "2026-05-26")

def write_post(post_id, frontmatter, body)
  dir = File.join(ROOT, "content", "blogs", post_id)
  FileUtils.mkdir_p(dir)
  File.write(File.join(dir, "index.md"), +"---\n#{frontmatter.to_yaml.sub(/\A---\n/, "")}---\n\n#{body}\n")
end

def base_frontmatter(post_id, title, status)
  {
    "post_id" => post_id,
    "title" => title,
    "authors" => ["Genomics X AI Editors"],
    "authors_display" => [
      {
        "name" => "Genomics X AI Editors",
        "affiliation" => "Genomics x AI",
        "orcid" => ""
      }
    ],
    "editor" => "Genomics X AI Editors",
    "tags" => ["workflow", "doi", "scholar", "testing"],
    "categories" => ["Announcement"],
    "scope" => ["insights"],
    "audience" => ["general"],
    "labs" => ["Genomics x AI"],
    "status" => status,
    "revision" => 1,
    "date_submitted" => TODAY,
    "date_accepted" => status == "accepted" ? TODAY : nil,
    "date" => TODAY,
    "doi" => "",
    "zenodo_url" => "",
    "revision_history" => [
      {
        "version" => 1,
        "date" => TODAY,
        "notes" => "Initial lifecycle fixture",
        "doi" => "",
        "zenodo_url" => ""
      }
    ]
  }
end

body = <<~MARKDOWN
  {{< summary >}}
  This generated lifecycle fixture validates Google Scholar metadata and Zenodo DOI workflow behavior.
  {{< /summary >}}

  This post is generated during CI and should not be committed to the repository.
MARKDOWN

[
  ["submitted", "Submitted Lifecycle Fixture", "submitted"],
  ["withdrawn", "Withdrawn Lifecycle Fixture", "withdrawn"]
].each do |suffix, title, status|
  post_id = "#{POST_PREFIX}-#{suffix}"
  write_post(post_id, base_frontmatter(post_id, title, status), body)
end

draft_id = "#{POST_PREFIX}-draft"
draft_fm = base_frontmatter(draft_id, "Draft Lifecycle Fixture", "submitted")
draft_fm["draft"] = true
write_post(draft_id, draft_fm, body)

accepted_id = "#{POST_PREFIX}-accepted"
accepted_fm = base_frontmatter(accepted_id, "Production DOI Lifecycle Validation Fixture", "accepted")
accepted_fm["revision"] = REVISION
accepted_fm["revision_history"] = (1..REVISION).map do |version|
  {
    "version" => version,
    "date" => TODAY,
    "notes" => "Lifecycle fixture revision #{version}",
    "doi" => "",
    "zenodo_url" => ""
  }
end

accepted_body = <<~MARKDOWN
  {{< summary >}}
  This generated accepted fixture validates production Zenodo DOI creation, versioned DOI updates, and Google Scholar metadata rendering.
  {{< /summary >}}

  This CI-generated operational test fixture is revision #{REVISION}.

  It exists only in the workflow workspace. The resulting Zenodo record is a permanent production DOI test record.
MARKDOWN

write_post(accepted_id, accepted_fm, accepted_body)

paths = [
  "#{POST_PREFIX}-submitted",
  "#{POST_PREFIX}-withdrawn",
  "#{POST_PREFIX}-draft",
  accepted_id
].map { |post_id| File.join("content", "blogs", post_id, "index.md") }

File.write("/tmp/lifecycle-blog-posts.txt", paths.join("\n") + "\n")
File.write("/tmp/lifecycle-accepted-post.txt", File.join("content", "blogs", accepted_id, "index.md") + "\n")
puts paths.join("\n")
