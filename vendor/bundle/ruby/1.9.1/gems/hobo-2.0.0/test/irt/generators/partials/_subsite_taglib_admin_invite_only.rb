desc "Taglib admin invite-only file matches with #{user_resource_name}"
file_include?("app/views/taglibs/subs_site.dryml", tags, invite_only)
test_value_eql? true
