class ExpenditurePolicy < ApplicationPolicy
  def access?
    user_is_manager?
  end

  def manage?
    user_is_accaontant?
  end
end
