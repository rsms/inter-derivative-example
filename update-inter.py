import sys, os, os.path, shutil
import openstep_plist
from multiprocessing import Pool

FAMILY = "Lolcat"
TAG    = FAMILY.lower()  # glyphs with this tag are not patched
SRCDIR = os.path.dirname(os.path.abspath(__file__))


def copy_glyph(src_glyphs_dir, dst_glyphs_dir, filename):
  # if filename != "A_.glyph" and filename != "a.glyph":
  #   return 0

  dst_file = os.path.join(dst_glyphs_dir, filename)
  with open(dst_file, 'r') as fp:
    dst_plistdata = fp.read()

  pl = openstep_plist.loads(dst_plistdata, use_numbers=True)

  # # Idea: customize per-layer by including a guide named TAG
  # layers = pl.get("layers")
  # if layers and len(layers) > 0:
  #   for i in range(len(layers)):
  #     layer = layers[i]
  #     guides = layer.get("guides")
  #     if guides:
  #       for guide in guides:
  #         if guide.get("name") == TAG:
  #           print("layer[%d] is custom" % i)
  #           break

  tags = pl.get("tags")
  if tags and TAG in tags:
    print("skip", filename)
    return 0

  src_file = os.path.join(src_glyphs_dir, filename)
  try:
    with open(src_file, 'r') as fp:
      src_plistdata = fp.read()
    if src_plistdata != dst_plistdata:
      print("COPY", filename)
      shutil.copyfile(src_file, dst_file)
      return 1
  except Exception as err:
    print("skip %s (%s)" % (filename, err))
  return 0


def on_copy_glyph_error(err):
  print("Error in copy_glyph: %s" % err)
  print(sys.exc_info()[2])


def main(argv):
  if not "-pass" in argv:
    print('Please run update-inter.sh instead', file=sys.stderr)
    sys.exit(1)
    return

  src_dir = os.path.join(SRCDIR, "inter", "src", "Inter.glyphspackage")
  src_glyphs_dir = os.path.join(src_dir, "glyphs")

  dst_dir = os.path.join(SRCDIR, FAMILY + "Inter.glyphspackage")
  dst_glyphs_dir = os.path.join(dst_dir, "glyphs")

  with Pool(16) as pool:
    results = []
    with os.scandir(os.path.join(src_dir, "glyphs")) as it:
      for entry in it:
        if not entry.name.startswith('.') and entry.is_file():
          # print(entry.name)
          res = pool.apply_async(copy_glyph,
            (src_glyphs_dir, dst_glyphs_dir, entry.name),
            error_callback=on_copy_glyph_error)
          results.append(res)
    pool.close()
    pool.join()
    nchanges = sum([res.get() for res in results])
    if nchanges == 0:
      print("No changes.")
      return
    print("Applied %d changes." % nchanges)
    print("Don't forget to File → Revert if you have the glyphs file open.")


if __name__ == '__main__':
  main(sys.argv)
