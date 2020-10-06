# frozen_string_literal: true

module SolidusKustomer
  class CreateError < RuntimeError; end
  class CustomerCreateError < RuntimeError; end
  class CustomerUpdateError < RuntimeError; end
  class NotFoundError < RuntimeError; end
end
