###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class Base64Image < StringIO
  UnsupportedFormat = Class.new(StandardError)

  EXTENSIONS = %w[jpg jpeg png gif tiff]

  attr_reader :content_type
  attr_reader :encoded_file

  #
  # Decodes Base64 encoded inline string image.
  #
  # ==== Parameters
  #
  # * +contents+ - String, Base64 decoded inline image containing header:
  #   <tt>data:image/png;base64,...</tt>
  #
  def initialize(contents)
    self.content_type, self.encoded_file = contents.split(';', 2)

    raise UnsupportedFormat unless valid_extension?

    super(Base64.decode64(encoded_file))
  end

  def original_filename
    "base64image.#{extension}"
  end

  def content_type=(value)
    @content_type = value.split(':').last
  end

  def encoded_file=(value)
    @encoded_file = value.split(',', 2).last
  end

  def extension
    content_type.split('/').last.to_s.downcase
  end

  def valid_extension?
    EXTENSIONS.include?(extension)
  end
end
