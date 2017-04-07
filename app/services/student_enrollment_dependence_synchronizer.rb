class StudentEnrollmentDependenceSynchronizer

  def self.synchronize!(synchronization, years)
    new(synchronization, years).synchronize!
  end

  def initialize(synchronization, years)
    self.synchronization = synchronization
    self.years = years
  end

  def synchronize!
    destroy_records
    years.each do |year|
      create_records api.fetch(ano: year)["matriculas"]
    end
  end

  protected

  attr_accessor :synchronization, :years

  def api
    IeducarApi::StudentEnrollmentDependences.new(synchronization.to_api)
  end

  def create_records(collection)

    ActiveRecord::Base.transaction do
      if collection.present?
        collection.each do |record|
          student_enrollment_dependences.create(
            student_enrollment_id: student_enrollments.find_by(api_code: record['matricula_id']).try(:id),
            student_enrollment_code: record['matricula_id'],
            discipline_id: disciplines.find_by(api_code: record['disciplina_id']).try(:id),
            discipline_code: record['disciplina_id']
          )
        end
      end
    end
  end

  def destroy_records
    student_enrollment_dependences.destroy_all
  end

  def student_enrollment_dependences(klass = StudentEnrollmentDependence)
    klass
  end

  def disciplines(klass = Discipline)
    klass
  end

  def student_enrollments(klass = StudentEnrollment)
    klass
  end
end
