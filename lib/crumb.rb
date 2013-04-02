# breadcrumb navigation
include Nanoc::Helpers::Breadcrumbs

def breadcrumbs
  breadcrumbs_trail.map do |crumb|
    {
      link: crumb.identifier,
      title: (crumb[:short_title] || crumb[:title] || crumb.name).to_s,
    }
  end
end
