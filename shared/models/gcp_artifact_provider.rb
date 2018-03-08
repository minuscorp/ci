require_relative "artifact_provider"
require_relative "artifact"
require_relative "build"
require_relative "project"

require "google/cloud/storage"
require "pathname"

module FastlaneCI
  # ArtifactProvider backed by a Google Cloud Platform Storage bucket.
  class GCPStorageArtifactProvider < ArtifactProvider
    class << self
      # Provide a simple default root_path for users that don't want much configuration.
      def root_browser
        "https://console.cloud.google.com/storage/browser/"
      end
    end

    # @return [String]
    attr_accessor :cloud_project

    # @return [String]
    attr_accessor :json_keyfile_path

    # @return [String]
    attr_accessor :bucket_name

    # @return [Google::Cloud::Storage]
    attr_accessor :storage

    # @return [Google::Cloud::Storage::Bucket]
    attr_accessor :bucket

    # @return [String] The class of the provider
    attr_accessor :class_name

    def initialize(cloud_project: nil, json_keyfile_path: nil, bucket_name: nil)
      self.cloud_project = cloud_project
      self.json_keyfile_path = json_keyfile_path
      self.bucket_name = bucket_name
      self.class_name = self.class.name.to_s
    end

    def init_storage!
      self.storage = Google::Cloud::Storage.new(
        project_id: self.cloud_project,
        credentials: self.json_keyfile_path
      )
      self.bucket = self.storage.bucket(self.bucket_name)
      permissions = self.bucket.test_permissions("storage.buckets.get", "storage.buckets.write")
      raise "Not enough permissions to the requested bucket" \
        unless permissions.include?("storage.buckets.get") && permissions.include?("storage.buckets.write")
    end

    def store!(artifact: nil, build: nil, project: nil)
      raise "Artifact to store was not provided or wrong type provided" if artifact.nil? || artifact&.class&.is_a?(Artifact)
      raise "Build was not provided or wrong type provided" if build.nil? || build&.class&.is_a?(Build)
      raise "Project was not provided or wrong type provided" if project.nil? || project&.class&.is_a?(Project)

      init_storage!

      original_artifact_reference = Pathname.new(artifact.reference)

      raise "Artifact reference not found." unless File.exist?(original_artifact_reference)

      new_artifact_reference = File.join(project.id, build.number.to_s, artifact.type, File.basename(original_artifact_reference))

      file = self.bucket.create_file(original_artifact_reference.to_s,
                                     new_artifact_reference)

      raise "File couldn't be created" if file.nil?

      artifact.reference = new_artifact_reference
      artifact.provider = self
      artifact # This is the Artifact that we will store in the build.
    end

    def retrieve!(artifact: nil)
      raise "Artifact to store was not provided or wrong type provided" if artifact.nil? || artifact&.class&.is_a?(Artifact)

      init_storage!

      file = self.bucket.file(artifact.reference)
      raise "Artifact reference not found" if file.nil?

      # TODO: For now is ok to return just the link to the browser in the GCP Console itself,
      # this should be revisited later to address how we generate permanent public links to the artifact
      # if the bucket is public (read-public) or expiring links for private buckets.
      "#{self.class.root_browser}#{self.bucket_name}/#{artifact.reference}"
    end
  end
end