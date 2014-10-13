class MetaJob < ActiveRecord::Base
  # Attributes: identifier, job_id
	def self.create_job job, job_identifier
		prev_meta_job = MetaJob.find_by(identifier: job_identifier)
		if prev_meta_job
			prev_job = Delayed::Job.find_by(id: prev_meta_job.job_id)
			prev_job.destroy if prev_job
			prev_meta_job.destroy
		end
		job_id = Delayed::Job.enqueue(job).id
		MetaJob.create! job_id: job_id, identifier: job_identifier
	end
end
