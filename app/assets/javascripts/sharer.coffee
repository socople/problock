(($, window) ->
  class Sharer
    constructor: (link) ->
      @link = link

      if @link.has("[data-count]").length
        @count()

      @link.on "click", (e) =>
        e.preventDefault()
        e.stopPropagation()
        @provider  = @link.data("provider")
        @url       = @link.data("url")      || window.location.href
        @content   = @link.data("content")  || ""
        @hashtags  = @link.data("hashtags") || ""
        @popup()

    patters: ->
      {
        facebook: "https://www.facebook.com/sharer/sharer.php?u=:url",
        twitter:  "https://twitter.com/intent/tweet?url=:url&text=:content&hashtags=:hashtags"
      }

    counters: ->
      {
        facebook: "http://graph.facebook.com/?id=:url&callback=?",
        twitter:  "https://cdn.api.twitter.com/1/urls/count.json?url=:url&callback=?"
      }

    counturl: ->
      @counters()[@provider].replace(":url", @url)

    counting: ->
      {
        facebook: (data) ->
          data.shares || 0

        twitter: (data) ->
          data.count  || 0
      }

    count: ->
      $.getJSON @counturl()
        .done (data) =>
          @counter().text @counting()[@provider](data)
        .error ->
          @counter().text 0

    counter: ->
      @link.find("[data-count]:first")

    shareurl: ->
      url = @patters()[@provider]
      url = url.replace(":url", @url)
      url = url.replace(":content", @content)
      url = url.replace(":hashtags", @hashtags)

    popup_placement: ->
      width  = 570
      height = 440
      left   = (screen.width  / 2) - (width / 2)
      top    = (screen.height / 2) - (height /2) - 100
      { width: width, height: height, left: left, top: top }

    fb_dialog: ->
      FB.ui({ method: 'feed', link: @url })

    popup: ->
      window.open(
        @shareurl(),
        "Sharer",
        "toolbar=no,
        location=no,
        directories=no,
        status=no,
        menubar=no,
        scrollbars=no,
        resizable=no,
        copyhistory=no,
        width=#{@popup_placement().width},
        height=#{@popup_placement().height},
        top=#{@popup_placement().top},
        left=#{@popup_placement().left}"
      )

  $.fn.extend Sharer: ->
    @each ->
      new Sharer($(this))

) window.jQuery, window
