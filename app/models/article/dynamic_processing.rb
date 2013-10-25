# This module enables create/update/delete of Articles based on the action
# attribute. Currently used for mass uploads.
#
# == License:
# Fairnopoly - Fairnopoly is an open-source online marketplace.
# Copyright (C) 2013 Fairnopoly eG
#
# This file is part of Fairnopoly.
#
# Fairnopoly is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# Fairnopoly is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Fairnopoly.  If not, see <http://www.gnu.org/licenses/>.
#
module Article::DynamicProcessing
  extend ActiveSupport::Concern

  included do
    # Action attribute: c/create/u/update/d/delete - for export and csv upload
    attr_accessor :action

    # Will be set according to action and used to modify the "save!" command
    attr_accessor :requested_state


    # When an action is set, modify the save call to reflect what should be done
    # @return [Article] Article ready to save or state changed
    def self.create_or_find_according_to_action attribute_hash, user
      case attribute_hash['action']
      when 'c', 'create'
        Article.new attribute_hash
      when 'u', 'update', 'x', 'delete', 'a', 'activate', 'd', 'deactivate'
        Article.process_dynamic_update attribute_hash, user
      when nil
        attribute_hash['action'] = Article.get_processing_default attribute_hash
        Article.create_or_find_according_to_action attribute_hash, user #recursion happens once
      else
        Article.create_error_article 'Unknown action'
      end
    end

    private
      # We alloy sellers to use their custom field as an identifier but we need the ID internally
      def self.find_by_id_or_custom_seller_identifier attribute_hash, user
        if attribute_hash['id']
          article = user.articles.where(id: attribute_hash['id']).first
        elsif attribute_hash['custom_seller_identifier']
          article = user.articles.
            where(custom_seller_identifier: attribute_hash['custom_seller_identifier']).
            limit(1).first
        else
          article = Article.create_error_article 'No unique identifier'
        end

        unless article
          article = Article.create_error_article 'Couldnt be found'
        end

        article
      end

      # Process update or state change
      def self.process_dynamic_update attribute_hash, user
        article = Article.find_by_id_or_custom_seller_identifier attribute_hash, user

        case attribute_hash['action']
        when 'u', 'update'
          article.attributes = attribute_hash
        when 'x', 'delete'
          article.requested_state = :closed
        when 'a', 'activate'
          article.requested_state = :activated
        when 'd', 'deactivate'
          article.requested_state = :deactivated
        end

        article
      end

      # Defaults: create when no ID is set, update when an ID exists
      # @return [String]
      def self.get_processing_default attribute_hash
        attribute_hash['id'] ? 'update' : 'create'
      end

      # Get article with error message for display in mass upload list
      def self.create_error_article error_message
        article = Article.new
        article.errors.add error_message
        article
      end
  end

  # Replacement for save! method - Does different things based on the requested_state attribute
  def process!
    case self.requested_state
    when :closed
      self.deactivate
      self.close
    when :activated
      self.activate
    when :deactivated
      self.deactivate
    else
      self.save!
    end
  end
end