class InitialsAvatar < Sinatra::Base
  # Canvas sizes
  DEFAULT_OUTPUT_SIZE = 70
  MIN_CANVAS_SIZE = 70

  # Font size as a proportion of the canvas
  FONT_RATIO = 0.45

  # Shift down text 4% from the center, since we're using caps
  Y_OFFSET = 0.04

  # Resize filter and sharpness settings
  # See http://stackoverflow.com/a/13243833/102542 for samples
  RESIZE_FILTER = Magick::LagrangeFilter
  RESIZE_BLUR = 1

  HEX_REGEX = /([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/

  get "/" do
    redirect "http://www.apptoto.com/"
  end

  get "/:initials.?:format?" do
    content_type "image/png"

    # Support initials_color
    initials = params[:initials].split("_")
    bg = initials[1] if initials.length > 1
    fg = initials[2] if initials.length > 2
    size = initials[3] if initials.length > 3
    initials = initials[0]

    return "No thanks" if initials.length > 3

    # Background color
    background_color = bg ? bg : (params[:bg] ? "#{params[:bg]}" : "DBDBDB")
    background_color = "#" << background_color if background_color =~ HEX_REGEX

    # Fill / Foreground color
    fill = fg ? fg : (params[:fg] ? "#{params[:fg]}" : "000000")
    fill = "#" << fill if fill =~ HEX_REGEX

    # Output/canvas sizes
    output_size = size ? size.to_i : (params[:s] ? params[:s].to_i : DEFAULT_OUTPUT_SIZE)
    canvas_size = [output_size, MIN_CANVAS_SIZE].max

    # Create the canvas
    img = Magick::Image.new(canvas_size, canvas_size) do
      self.format = "png"
      self.background_color = background_color
    end

    # Create the text annotation
    Magick::Draw.new.annotate(img, canvas_size,canvas_size,0,canvas_size*Y_OFFSET, initials[0..2].upcase) do
      self.fill = fill
      self.gravity = Magick::CenterGravity
      self.pointsize = canvas_size*FONT_RATIO
      self.font_weight = Magick::BoldWeight
    end

    # Resize the image to desired size
    img = img.resize(output_size,output_size, RESIZE_FILTER, RESIZE_BLUR)

    # Return the raw image data
    img.to_blob { self.format = "PNG" }
  end
end
