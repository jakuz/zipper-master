module ApplicationHelper

  def flash_class(type)
    case type.to_sym
    when :notice then "alert-success"
    when :alert then "alert-danger"
    end
  end

end
