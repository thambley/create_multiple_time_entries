class MultiuserTimeEntry < TimeEntry
  attr_accessor :user_ids
  
  safe_attributes 'user_ids'
  
  validate :user_ids_can_not_be_empty
  
  def users
    User.where(:id => self.user_ids)
  end
  
  def valid?
    @time_entries = []
    (@user_ids || []).each do |user_id|
      time_entry = TimeEntry.new(:project => project, :user => User.find(user_id))
      time_entry.safe_attributes = self.attributes
      time_entry.custom_field_values = self.custom_field_values.inject({}) {|h,v| h[v.custom_field_id] = v.value; h}
      @time_entries << time_entry
    end
    
    super
    self.errors.delete :user_id
    
    errors.empty? && @time_entries.all?(&:valid?)
  end
  
  def save
    if valid?
      saved = MultiuserTimeEntry.transaction do
        @time_entries.each do |t|
          yield t if block_given?
          unless t.save
            raise ActiveRecord::Rollback
          end
        end
      end
    else
      false
    end
  end
  
  def available_custom_fields
    CustomField.where("type = 'TimeEntryCustomField'").sorted.all
  end
  
  private
  
  def user_ids_can_not_be_empty
    errors.add(:user_ids, :empty) if user_ids.blank?
  end
  
end