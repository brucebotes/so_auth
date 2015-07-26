require 'uri'
require 'net/http'

module SoAuth
  class ApplicationController < ActionController::Base

    protect_from_forgery
    #temporary disabled because I cannot get cookies to work
    before_filter :check_cookie
    def check_cookie
      if !cookie_valid?
        session[:user_id] = nil
      end
    end

    def cookie_valid?
      cookies[:so_auth].present? && session[:user_id].present? && cookies[:so_auth].to_s == session[:user_id].to_s
    end

    def login_required
      if !current_user
        not_authorized
      end
    end

    def not_authorized
      respond_to do |format|
        format.html{ auth_redirect }
        format.json{ head :unauthorized }
      end
    end

    def auth_redirect
      observable_redirect_to "/auth/so?origin=#{request.protocol}#{request.host_with_port}#{request.fullpath}"
    end

    def current_user
      return nil unless session[:user_id]
      @current_user ||= User.find_by_id(session[:user_id])
    end

    def signed_in?
      current_user.present?
    end

    def sign_up_new_user( user_details )
      #call the so_auth_provider api
      url = URI.parse( "#{ENV['AUTH_PROVIDER_URL']}/api/v1/users.json" )
      req = Net::HTTP::Post.new( url.request_uri, initheader = {'Content-Type' =>'application/json'} )
      req.body =  {:user => user_details}.to_json
      http = Net::HTTP.new( url.host, url.port )
      http.use_ssl = ( url.scheme == "https" )
      response = http.request( req )
      case response.code
      when '201'
        user_data = JSON.parse( response.body )
        user = User.find_or_create_by('id'=> user_data['id'])
        user.update('email' => user_data['email'])
        Rails.logger.debug "Added new user #{user_data['email']} to this app."
        user
       else
        binding.pry
        nil
      end
    end


    helper_method :signed_in?
    helper_method :current_user




    private

    # These two methods help with testing
    def integration_test?
      Rails.env.test? && defined?(Cucumber::Rails)
    end

    def observable_redirect_to(url)
      if integration_test?
        render :text => "If this wasn't an integration test, you'd be redirected to: #{url}"
      else
        redirect_to url
      end
    end

  end
end
