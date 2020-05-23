# frozen_string_literal: true

# Use the Pipeline object to start Pipeline operations.
#
# Each step in the pipeline will accept and return a Struct called Pipeline.
# This allows us to build the pipeline in a streamlined manner. The attributes
# of the Pipeline are:
#   - code:    Return code
#                200 = success
#                4** = user error
#                5** = internal error
#                6** = special error for internal use only
#                NOTE:  Use standard HTTP response codes as much as possible.
#   - payload: In the case of a new Pipeline, just the input value. Can be
#              anything that we want to work on. An object, a collection of
#              objects, etc.
#   - message: Shows error messages. Default is nil to indicate no problems
#   - error: Includes the Ruby Exception object
#
# NOTE: We should think about object types and default values here.
Pipeline = Struct.new(:code, :payload, :message, :errors)
