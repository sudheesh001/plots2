# def subdomain
# def show
# def raw
# def edit
# def new
# def create
# def update
# def delete
# def revert
# def root
# def revisions
# def revision
# def index
# def popular
# def liked

require 'test_helper'

class WikiControllerTest < ActionController::TestCase

  def setup
    activate_authlogic
    @user =  FactoryGirl.create(:user)
  end

  def teardown
    @user.destroy
  end

  test "should get wiki index" do
    get :index
    assert_response :success
    assert_not_nil :wikis
  end

  test "should get raw wiki markup" do
    id = DrupalNodeRevision.last.id
    get :raw, id: id
    assert_response :success
  end

  test "should get wiki page" do
    id = DrupalNode.where(type: 'page').last.id
    get :show, id: id
    assert_response :success
  end

  test "post wiki no login" do
    # kind of weird, to successfully log out, we seem to have to first log in to get the UserSession...
    user_session = UserSession.create @user
    user_session.destroy
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to('/login?return_to=/wiki/create')
  end

  test "post wiki" do
    UserSession.new(@user)
    title = "All about balloon mapping"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/"+title.parameterize
    #assert_response :success
    #assert_template "wiki/show"
  end

  test "edit wiki" do
    UserSession.new(@user)
    title = "All about balloon mapping redux"
    post :create, :uid => @user.id, :title => title, :body => "This is fascinating documentation about balloon mapping.", :tags => "balloon-mapping,event"
    assert_redirected_to "/wiki/"+title.parameterize

    # add a tag, and change the title and body
    newtitle = title + " which I amended"
    nid = DrupalNodeRevision.find_by_title(title).nid
    post :update, :id => nid, :title => newtitle, :body => "This is fascinating documentation about balloon mapping. <span id='teststring'>added content</span>", :tags => "balloon-mapping,event,meetup"
    assert_redirected_to "/wiki/"+title.parameterize

    get(:show, {:id => title.parameterize}) 
    assert_response :success
    assert_equal flash[:notice], "Edits saved."
    # This is WRONG! It should be newtitle, not title, right?:
    assert_select "h1", newtitle # title should change but not URL
    # assert_select "span#teststring", "added content" # this test does not work! very frustrating. 
    # assert_select ".label", "meetup" # test for tag addition too, later
  end

end
