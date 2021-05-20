module Spree
  module AbilityDecorator

    def initialize(user, external_roles = [])
      self.clear_aliased_actions

      alias_action :edit, to: :update
      alias_action :new, to: :create
      alias_action :new_action, to: :create
      alias_action :show, to: :read
      alias_action :index, to: :read
      alias_action :delete, to: :destroy

      @user = user || Spree.user_class.new

      @external_roles = external_roles

      token_roles&.map(&:permissions).flatten.uniq.map { |permission| permission.ability(self, @user) }

      Ability.abilities.each do |clazz|
        ability = clazz.send(:new, @user)
        @rules = rules + ability.send(:rules)
      end
    end

    def token_roles
      (roles = Spree::Role.where(name: @external_roles).includes(:permissions)).empty? ? Spree::Role.default_role.includes(:permissions) : roles
    end
  end
end

::Spree::Ability.prepend Spree::AbilityDecorator
