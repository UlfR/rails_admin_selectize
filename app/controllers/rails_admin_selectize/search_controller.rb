module RailsAdminSelectize
  class SearchController < ApplicationController
    def index
      search = collection.search(params[:q])
      render json: serialize(search.result.limit(field_config.search_limit))
    end

    private

    def serialize(instances)
      instances.map do |instance|
        {
          text: instance.send(field_config.search_text_field),
          value: instance.send(field_config.search_value_field)
        }
      end
    end

    def field_config
      @field_config ||= begin
        model_name = params[:parent_model_name].to_sym
        parent_config = RailsAdmin::Config.registry[model_name].abstract_model.config

        config = parent_config.send(params[:parent_action]).fields.find do |field|
          field.name == field_name
        end

        config.bindings = { object: parent_model.new }

        config
      end
    end

    def field_name
      @field_name ||= params[:field_name].to_sym
    end

    def collection
      @collection ||= field_config.associated_collection_scope.call(
        parent_model.reflections[field_config.relation_name || field_name].klass
      )
    end

    def parent_model
      @parent_model ||= params[:parent_model_name].constantize
    end
  end
end
