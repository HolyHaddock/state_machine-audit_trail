# This is the class that does the actual logging.
# We need one of these per ORM

class StateMachine::AuditTrail::Backend::Mongoid < StateMachine::AuditTrail::Backend
  attr_accessor :context_to_log

  def initialize(transition_class, owner_class, context_to_log = nil)
    self.context_to_log = context_to_log
    super transition_class, owner_class
  end


  # Public writes the log to the database
  #
  # object: the object being watched by the state_machine observer
  # event:  the event being observed by the state machine
  # from:   the state of the object prior to the event
  # to:     the state of the object after the event
  def log(object, event, from, to, timestamp = Time.now)
    owner_key_field = owner_class.relations.keys.first
    transition_key_field = transition_class.relations.keys.first
    params = {:event => event, :from => from, :to => to, :created_at => timestamp}
    [context_to_log].flatten(1).each { |context| params[context] = object.send(context) } unless self.context_to_log.nil?
    new_transition = object.send(owner_key_field).build(params)
    new_transition.save!
  end

end
