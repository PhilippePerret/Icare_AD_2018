# encoding: UTF-8

def enable_comments
  Page::Comments.set_comments_on
end
def unable_comments
  Page::Comments.set_comments_off
end

def mobile_separator
  Page.mobile_separator
end

def space
  '<div>&nbsp;&nbsp;&nbsp;</div>'
end
