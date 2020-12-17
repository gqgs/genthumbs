Generate video mosaic previews.

### Installation

```
make install
```

### Usage

```
genThumbs [videos]
```

### Docker

```
make build

docker run -v "$(pwd)":/home/ genthumbs [videos]
```

### Dependencies
 - `ffmpeg`
 - `ffprobe`
 - `bc`
 
 ### Examples

 ![BigBuckBunny](/assets/BigBuckBunny.jpg)
 ![owarimonogatari](/assets/owarimonogatari.jpg)
 ![bonobo](/assets/bonobo.jpg)
