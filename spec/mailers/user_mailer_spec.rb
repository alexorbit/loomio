require "rails_helper"

describe UserMailer do
  shared_examples_for 'email_meta' do
    it 'renders the receiver email' do
      expect(@mail.to).to eq [@user.email]
    end

    it 'renders the sender email' do
      expect(@mail.from).to include BaseMailer::NOTIFICATIONS_EMAIL_ADDRESS
    end
  end

  context 'sending email on membership approval' do
    before :each do
      @user = create(:user)
      @group = create(:formal_group)
      @membership = create(:membership, user: @user, group: @group)
      @event = Events::MembershipRequestApproved.create(kind: 'membership_request_approved', user: @user, eventable: @membership)
      @mail = UserMailer.membership_request_approved(@user, @event)
    end

    it_behaves_like 'email_meta'

    it 'assigns correct reply_to' do
      expect(@mail.reply_to).to eq [@group.admin_email]
    end

    it 'renders the subject' do
      expect(@mail.subject).to eq "Your request to join #{@group.full_name} on Loomio has been approved"
    end

    it 'assigns confirmation_url for email body' do
      @mail.body.encoded.should match(@group.key)
    end

  end

  context 'sending email on being added to group' do
    before :each do
      @user = create(:user)
      @inviter = create(:user)
      @group = create(:formal_group, full_name: "Group full name")
      @membership = create(:membership, user: @user, group: @group, inviter: @inviter)
      @event = Events::UserAddedToGroup.create(kind: 'user_added_to_group', user: @inviter, eventable: @membership)
      @mail = UserMailer.user_added_to_group(@user, @event)
    end

    it 'renders the subject' do
      expect(@mail.subject).to eq "#{@inviter.name} has added you to #{@group.full_name} on Loomio"
    end

    it 'uses group.full_name in the email body' do
      expect(@mail.body.encoded).to  include @group.full_name
    end
  end

  describe 'missed_yesterday' do
    let(:user) { create :user, email_missed_yesterday: true }
    subject { UserMailer.missed_yesterday(user).deliver_now }
    let(:discussion) { build :discussion, group: group }
    let(:comment) { build :comment, discussion: discussion }
    let(:group) { create :formal_group }
    before { group.add_member! user }

    let(:some_content) do
      DiscussionService.create(discussion: discussion, actor: discussion.author)
      CommentService.create(comment: comment, actor: comment.author)
    end

    it 'sends a missed yesterday email' do
      some_content
      expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does not send a missed yesterday email when there is no unread content' do
      expect { subject }.to_not change { ActionMailer::Base.deliveries.count }
    end

    it 'does not send a missed yesterday email if I have unsubscribed' do
      user.update(email_missed_yesterday: false)
      some_content
      expect { subject }.to_not change { ActionMailer::Base.deliveries.count }
    end
  end

end
