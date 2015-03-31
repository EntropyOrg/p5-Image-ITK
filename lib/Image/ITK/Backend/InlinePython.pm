package Image::ITK::Backend::InlinePython;

use strict;
use warnings;

use Inline Python => <<'END';
import itk

class itkProxy(object):
  def __init__(self, target):
    self._target = target

  def __str__(self):
    return str(self._target)

  def __repr__(self):
    return repr(self._target)

  def __getattr__(self, aname):
    target = self._target
    f = getattr(target, aname)

    def wrap_it(*args):
      u_args_l = []; # final arguments
      for arg in args:
        arg = getattr( arg, '_target', arg )
        u_args_l.append( arg )
      u_args = tuple(u_args_l)

      # proxy the return value
      if( type(f).__name__ == 'itkTemplate' ):
        # using __getitem__ instead of .get() so that
        # exception is thrown for missing keys
        templated_result = f.__getitem__(u_args)
        return itkProxy(templated_result)
      elif type(f).__name__ == 'instance':
        return itkProxy(f)
      elif callable(f):
        return itkProxy(f(*u_args))

    return wrap_it

my_itk = itkProxy(itk)
END

sub AUTOLOAD {
    (my $call = our $AUTOLOAD) =~ s/.*:://;

    # check if syntax is correct
    die "Not a Python identifier: $call" unless( $call =~ /^[^\d\W]\w*\Z/ );

    my $itk = Inline::Python::py_eval("my_itk", 0);
    Inline::Python::py_call_method($itk, $call, @_);
}

1;
