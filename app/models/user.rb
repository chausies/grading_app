class User < ActiveRecord::Base
  has_many :enrollments, foreign_key: "participant_id", dependent: :destroy
  has_many :courses, through: :enrollments

  before_save { self.email = email.downcase }
  before_create :create_remember_token
  
  validates :name,  presence: true,
            length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: { case_sensitive: false}

  has_secure_password
  validates :password, length: { minimum: 6 }

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def enrolled?(course_id)
    self.enrollments.find_by(course_id: course_id)
  end

  def enroll!(course_id, status, sid = "")
    self.enrollments.create!(course_id: course_id, status: status, sid: sid)
  end

  private

    def create_remember_token
      self.remember_token = User.digest(User.new_remember_token)
    end

end
