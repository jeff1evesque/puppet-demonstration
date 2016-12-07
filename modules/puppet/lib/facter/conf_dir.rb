# define facter
Facter.add(:conf_dir) do
  setcode do
    Facter::Core::Execution.exec('puppet config print confdir')
  end
end