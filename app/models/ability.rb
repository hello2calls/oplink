class Ability
	include CanCan::Ability

	def initialize(user)
		if user and user.admin?
			can :manage, :all
		elsif user and not user.admin?
			can :read, :all
		end
	end
end