defmodule GameHubWeb.HomeLive do
  use GameHubWeb, :live_view

  @games [
    %{
      slug: "co-ca-ngua",
      name: "Cờ cá ngựa",
      tagline: "Ludo phiên bản Việt Nam",
      description:
        "Tung xúc xắc, đưa 4 chú ngựa về chuồng trước tiên. Luật đơn giản, bé 5 tuổi chơi được ngay.",
      image: "/images/assets/horse_red.webp",
      players: "2–4 người",
      age: "5 tuổi trở lên",
      minutes: "15–30 phút",
      accent_text: "text-toy-red",
      accent_tint: "bg-toy-red/15",
      path: "/games/co-ca-ngua",
      status: :ready
    },
    %{
      slug: "co-vua",
      name: "Cờ vua",
      tagline: "Chess",
      description:
        "Ván cờ kinh điển của cả thế giới. Rèn khả năng nhìn trước nhiều nước đi cho bé.",
      image: "/images/ui/piece_chess.webp",
      players: "2 người",
      age: "6 tuổi trở lên",
      minutes: "20–40 phút",
      accent_text: "text-toy-blue",
      accent_tint: "bg-toy-blue/15",
      path: nil,
      status: :soon
    },
    %{
      slug: "co-tuong",
      name: "Cờ tướng",
      tagline: "Xiangqi",
      description:
        "Ván cờ quen thuộc của ông bà, ba mẹ. Tướng, sĩ, tượng, xe, pháo, mã, tốt — qua sông là đổi thế trận.",
      image: "/images/ui/piece_xiangqi.webp",
      players: "2 người",
      age: "7 tuổi trở lên",
      minutes: "20–40 phút",
      accent_text: "text-toy-yellow-dark",
      accent_tint: "bg-toy-yellow/20",
      path: nil,
      status: :soon
    },
    %{
      slug: "co-vay",
      name: "Cờ vây",
      tagline: "Go / Baduk",
      description:
        "Luật chỉ có vài dòng nhưng chơi cả đời không chán. Đặt quân, vây đất, ai nhiều đất hơn thì thắng.",
      image: "/images/ui/piece_go.webp",
      players: "2 người",
      age: "7 tuổi trở lên",
      minutes: "20–45 phút",
      accent_text: "text-toy-green-dark",
      accent_tint: "bg-toy-green/20",
      path: nil,
      status: :soon
    }
  ]

  @steps [
    %{
      icon: "device",
      title: "Đặt máy giữa bàn",
      body:
        "Một chiếc điện thoại hoặc máy tính bảng là đủ. Không cần cài đặt, mở trình duyệt là chơi."
    },
    %{
      icon: "family",
      title: "Chọn người chơi",
      body: "Nhập tên ba, mẹ, bé... rồi chọn màu quân. Từ 2 đến 4 người cùng một ván."
    },
    %{
      icon: "tap",
      title: "Thay phiên nhau chạm",
      body:
        "Đến lượt ai, máy sẽ sáng tên và nhắc người đó. Cả nhà nhìn chung một màn hình như bàn cờ thật."
    }
  ]

  @parent_reasons [
    %{
      icon: "shield",
      title: "Không quảng cáo, không mua trong ứng dụng",
      body:
        "Bé chơi một mình cũng không bấm nhầm vào thứ gì. Không có nút nạp tiền, không có video quảng cáo."
    },
    %{
      icon: "offline",
      title: "Không cần tài khoản, không cần mạng",
      body:
        "Không đăng ký, không thu thập thông tin của bé. Đã mở một lần thì lúc đi xa vẫn chơi được."
    },
    %{
      icon: "brain",
      title: "Chơi mà học được thật",
      body:
        "Đếm số, tính nước đi, chờ tới lượt và chấp nhận thua — những thứ màn hình một mình không dạy được."
    },
    %{
      icon: "together",
      title: "Ngồi cạnh nhau, không ai cầm máy riêng",
      body:
        "Một thiết bị cho cả nhà nghĩa là cả nhà nhìn nhau, cười với nhau, thay vì mỗi người một màn hình."
    }
  ]

  @faqs [
    %{
      q: "Có cần hai điện thoại để chơi với nhau không?",
      a:
        "Không. Cả nhà dùng chung một máy, thay phiên nhau chạm — giống như ngồi quanh một bàn cờ thật."
    },
    %{
      q: "Có tốn tiền không?",
      a: "Miễn phí hoàn toàn. Không quảng cáo, không gói trả phí, không mua vật phẩm."
    },
    %{
      q: "Bé mấy tuổi chơi được?",
      a:
        "Cờ cá ngựa hợp với bé từ 5 tuổi: chỉ cần biết đếm chấm xúc xắc. Các trò cờ khác sẽ hợp hơn với bé 6–7 tuổi trở lên."
    },
    %{
      q: "Có chơi trên máy tính được không?",
      a:
        "Được. Trò chơi chạy trên trình duyệt, dùng tốt trên điện thoại, máy tính bảng và máy tính. Máy tính bảng đặt nằm giữa bàn là dễ chơi nhất."
    }
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Bé vui học — Cả nhà cùng chơi cờ trên 1 thiết bị",
       games: @games,
       steps: @steps,
       parent_reasons: @parent_reasons,
       faqs: @faqs,
       featured: hd(@games)
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <main>
      <.site_header />
      <.hero featured={@featured} />
      <.steps_section steps={@steps} />
      <.games_section games={@games} />
      <.parents_section reasons={@parent_reasons} />
      <.kids_section featured={@featured} />
      <.faq_section faqs={@faqs} />
      <.closing_cta featured={@featured} />
      <.site_footer />
    </main>
    """
  end

  # The one page shell: fluid on phones, and it keeps widening on large monitors
  # instead of stopping at a narrow fixed column.
  defp shell_class,
    do: "mx-auto w-full max-w-6xl px-4 sm:px-6 lg:max-w-7xl lg:px-8 2xl:max-w-[1560px] 2xl:px-12"

  # ----------------------------------------------------------------- header

  defp site_header(assigns) do
    ~H"""
    <header class={[shell_class(), "flex items-center justify-between py-5"]}>
      <a href="#top" class="flex items-center gap-2">
        <.toy_icon name="logo" class="h-11 w-11" />
        <span class="text-xl font-extrabold tracking-tight text-ink">
          Bé vui học
        </span>
      </a>

      <div class="flex items-center gap-3">
        <a
          href="#games"
          class="hidden items-center py-3.5 text-sm font-bold text-ink-soft hover:underline sm:flex"
        >
          Trò chơi
        </a>
        <a
          href="#ba-me"
          class="hidden items-center py-3.5 text-sm font-bold text-ink-soft hover:underline sm:flex"
        >
          Dành cho ba mẹ
        </a>
        <.link
          navigate={~p"/games/co-ca-ngua"}
          class="toy-btn toy-btn--red !px-4 !py-2 !text-base"
        >
          Chơi ngay
        </.link>
      </div>
    </header>
    """
  end

  # ------------------------------------------------------------------- hero

  attr :featured, :map, required: true

  defp hero(assigns) do
    ~H"""
    <section id="top" class="relative flex min-h-[calc(100svh-5.5rem)] items-center py-10 sm:py-14">
      <div class={[
        shell_class(),
        "grid items-center gap-10 lg:grid-cols-[1.05fr_1fr] lg:gap-14 2xl:gap-20"
      ]}>
        <div class="text-center lg:text-left">
          <span class="toy-chip">
            <.toy_icon name="device" class="h-6 w-6" /> Một thiết bị — cả nhà cùng chơi
          </span>

          <h1 class="mt-5 text-[2rem] font-extrabold leading-[1.15] tracking-tight sm:text-5xl lg:text-4xl xl:text-5xl 2xl:text-6xl text-ink">
            Cả nhà ngồi lại,<br />
            <span class="text-toy-red">chơi cờ chung 1 máy</span>
          </h1>

          <p class="mx-auto mt-5 max-w-xl text-lg leading-relaxed lg:mx-0 xl:text-xl text-ink-soft">
            Không cần hai điện thoại, không cần mạng, không cần tài khoản.
            Đặt máy xuống giữa bàn, chọn tên từng người, rồi thay phiên nhau chạm —
            y như mở một hộp cờ thật ra chơi.
          </p>

          <div class="mt-8 flex flex-col items-stretch gap-3 sm:flex-row sm:items-center sm:justify-center lg:justify-start">
            <.link navigate={@featured.path} class="toy-btn toy-btn--red !text-lg">
              <.toy_icon name="dice" class="h-7 w-7" /> Chơi {@featured.name} ngay
            </.link>
            <a href="#games" class="toy-btn toy-btn--neutral !text-lg">
              Xem các trò chơi
            </a>
          </div>

          <ul class="mt-8 flex flex-wrap justify-center gap-2 lg:justify-start">
            <li :for={
              chip <- ["Miễn phí", "Không quảng cáo", "2–4 người", "Chơi không cần mạng", "Từ 5 tuổi"]
            }>
              <span class="toy-chip !py-1.5 !text-xs">
                <.toy_icon name="check" class="h-5 w-5" /> {chip}
              </span>
            </li>
          </ul>
        </div>

        <div class="relative mx-auto w-full max-w-xl xl:max-w-2xl">
          <div class="toy-card overflow-hidden p-2 sm:p-3">
            <img
              src={~p"/images/landing/hero_family.webp"}
              alt="Ba mẹ và hai bé cùng ngồi quanh bàn, chơi cờ trên một chiếc máy tính bảng đặt giữa bàn"
              width="1400"
              height="788"
              fetchpriority="high"
              class="w-full rounded-[22px] object-cover"
            />
          </div>

          <img
            src={~p"/images/assets/die_5.webp"}
            alt=""
            aria-hidden="true"
            width="213"
            height="224"
            class="animate-float pointer-events-none absolute -top-6 left-0 w-16 drop-shadow-lg sm:-left-4 sm:w-20"
          />
          <img
            src={~p"/images/assets/horse_blue.webp"}
            alt=""
            aria-hidden="true"
            width="174"
            height="224"
            class="animate-float-slow pointer-events-none absolute right-0 -bottom-7 w-20 drop-shadow-lg sm:-right-3 sm:w-24"
          />
        </div>
      </div>

      <a
        href="#games"
        class="absolute inset-x-0 bottom-4 mx-auto hidden w-fit items-center gap-2 text-sm font-bold lg:flex text-ink-soft"
      >
        Kéo xuống xem các trò chơi
        <span class="animate-scroll-hint text-lg" aria-hidden="true">&darr;</span>
      </a>
    </section>
    """
  end

  # ------------------------------------------------------------------ steps

  attr :steps, :list, required: true

  defp steps_section(assigns) do
    ~H"""
    <section class="landing-band border-y-2 py-14 sm:py-20 2xl:py-28 border-cream-deep">
      <div class={shell_class()}>
        <div class="text-center">
          <h2 class="text-3xl font-extrabold tracking-tight sm:text-4xl text-ink">
            Chơi chung trên 1 thiết bị, dễ như vậy thôi
          </h2>
          <p class="mx-auto mt-3 max-w-2xl text-lg text-ink-soft">
            Ba bước, chưa tới một phút là ván cờ bắt đầu.
          </p>
        </div>

        <ol class="mt-10 grid gap-5 md:grid-cols-3 2xl:gap-8">
          <li :for={{step, i} <- Enum.with_index(@steps, 1)} class="toy-card p-6 text-center">
            <span class="toy-medallion">
              <.toy_icon name={step.icon} class="h-12 w-12" />
            </span>
            <p class="mt-4 text-sm font-extrabold text-toy-red">BƯỚC {i}</p>
            <h3 class="mt-1 text-xl font-extrabold text-ink">{step.title}</h3>
            <p class="mt-2 text-base leading-relaxed text-ink-soft">
              {step.body}
            </p>
          </li>
        </ol>
      </div>
    </section>
    """
  end

  # ------------------------------------------------------------------ games

  attr :games, :list, required: true

  defp games_section(assigns) do
    ~H"""
    <section id="games" class="scroll-mt-6 py-14 sm:py-20 2xl:py-28">
      <div class={shell_class()}>
        <div class="text-center">
          <h2 class="text-3xl font-extrabold tracking-tight sm:text-4xl text-ink">
            Tủ trò chơi của cả nhà
          </h2>
          <p class="mx-auto mt-3 max-w-2xl text-lg text-ink-soft">
            Những ván cờ bàn quen thuộc, chơi cùng nhau trên một màn hình.
            Trò chơi mới được thêm dần — đã mở là chơi được ngay, không phải tải lại.
          </p>
        </div>

        <div class="mt-10 grid gap-5 sm:grid-cols-2 lg:grid-cols-4 2xl:gap-8">
          <.game_card :for={game <- @games} game={game} />
        </div>
      </div>
    </section>
    """
  end

  attr :game, :map, required: true

  defp game_card(assigns) do
    ~H"""
    <.link
      :if={@game.status == :ready}
      navigate={@game.path}
      class="toy-card toy-card--link flex flex-col p-5"
      aria-label={"Chơi #{@game.name}"}
    >
      <.game_card_body game={@game} />
    </.link>

    <div :if={@game.status == :soon} class="toy-card toy-card--soon flex flex-col p-5">
      <.game_card_body game={@game} />
    </div>
    """
  end

  attr :game, :map, required: true

  defp game_card_body(assigns) do
    ~H"""
    <div class="flex items-start justify-between gap-2">
      <span class={[
        "inline-flex h-20 w-20 items-center justify-center rounded-[20px] text-4xl",
        @game.accent_tint
      ]}>
        <img
          src={@game.image}
          alt=""
          aria-hidden="true"
          width="160"
          height="160"
          class="h-16 w-16 object-contain"
        />
      </span>

      <span class={["toy-badge", badge_class(@game.status)]}>
        {badge_label(@game.status)}
      </span>
    </div>

    <h3 class="mt-4 text-xl font-extrabold text-ink">{@game.name}</h3>
    <p class={["text-sm font-bold", @game.accent_text]}>{@game.tagline}</p>
    <p class="mt-2 flex-1 text-sm leading-relaxed text-ink-soft">
      {@game.description}
    </p>

    <ul class="mt-4 space-y-1 text-xs font-semibold text-ink-soft">
      <li class="flex items-center gap-1.5">
        <.toy_icon name="players" class="h-5 w-5" /> Số người chơi: {@game.players}
      </li>
      <li class="flex items-center gap-1.5">
        <.toy_icon name="age" class="h-5 w-5" /> Hợp với bé {@game.age}
      </li>
      <li class="flex items-center gap-1.5">
        <.toy_icon name="timer" class="h-5 w-5" /> Một ván {@game.minutes}
      </li>
    </ul>

    <p :if={@game.status == :ready} class={["mt-4 text-sm font-extrabold", @game.accent_text]}>
      Bắt đầu chơi <span aria-hidden="true">→</span>
    </p>
    <p :if={@game.status == :soon} class="mt-4 text-sm font-bold text-ink-soft">
      Đang được làm, sắp có mặt trong tủ
    </p>
    """
  end

  defp badge_class(:ready), do: "toy-badge--ready"
  defp badge_class(:soon), do: "toy-badge--soon"

  defp badge_label(:ready), do: "Chơi được ngay"
  defp badge_label(:soon), do: "Sắp ra mắt"

  # ---------------------------------------------------------------- parents

  attr :reasons, :list, required: true

  defp parents_section(assigns) do
    ~H"""
    <section
      id="ba-me"
      class="landing-band scroll-mt-6 border-y-2 py-14 sm:py-20 2xl:py-28 border-cream-deep"
    >
      <div class={shell_class()}>
        <div class="text-center">
          <span class="toy-chip"><.toy_icon name="family" class="h-6 w-6" /> Gửi ba mẹ</span>
          <h2 class="mt-4 text-3xl font-extrabold tracking-tight sm:text-4xl text-ink">
            Thời gian trước màn hình, nhưng là ngồi cạnh nhau
          </h2>
          <p class="mx-auto mt-3 max-w-2xl text-lg text-ink-soft">
            Bé vui học được làm cho những buổi tối trong nhà và những chuyến đi xa —
            khi cả nhà chỉ có một chiếc máy và muốn chơi cùng nhau.
          </p>
        </div>

        <div class="mt-10 grid gap-5 sm:grid-cols-2 2xl:gap-8">
          <div :for={reason <- @reasons} class="toy-card flex gap-4 p-6">
            <span class="toy-medallion !h-14 !w-14 shrink-0">
              <.toy_icon name={reason.icon} class="h-9 w-9" />
            </span>
            <div>
              <h3 class="text-lg font-extrabold text-ink">{reason.title}</h3>
              <p class="mt-1 text-base leading-relaxed text-ink-soft">
                {reason.body}
              </p>
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  # ------------------------------------------------------------------- kids

  attr :featured, :map, required: true

  defp kids_section(assigns) do
    ~H"""
    <section class="py-14 sm:py-20 2xl:py-28">
      <div class={shell_class()}>
        <div class="toy-card overflow-hidden">
          <div class="grid items-center gap-8 p-7 sm:p-10 lg:grid-cols-[1fr_auto]">
            <div class="text-center lg:text-left">
              <span class="toy-chip"><.toy_icon name="party" class="h-6 w-6" /> Gửi các bạn nhỏ</span>
              <h2 class="mt-4 text-3xl font-extrabold tracking-tight sm:text-4xl text-ink">
                Rủ ba mẹ chơi một ván nha!
              </h2>
              <ul class="mx-auto mt-5 max-w-lg space-y-2.5 text-left text-lg lg:mx-0 text-ink-soft">
                <li class="flex gap-3">
                  <.toy_icon name="dice" class="h-7 w-7" />
                  Chạm vào xúc xắc để tung, xem được mấy chấm
                </li>
                <li class="flex gap-3">
                  <.toy_icon name="horse" class="h-7 w-7" />
                  Chọn chú ngựa đang nhấp nháy rồi cho nó chạy
                </li>
                <li class="flex gap-3">
                  <.toy_icon name="trophy" class="h-7 w-7" />
                  Ai đưa cả 4 chú ngựa về chuồng trước là thắng
                </li>
              </ul>
              <.link navigate={@featured.path} class="toy-btn toy-btn--blue mt-7 !text-lg">
                Chơi thử ngay <.toy_icon name="party" class="h-7 w-7" />
              </.link>
            </div>

            <div class="flex justify-center gap-3">
              <img
                :for={
                  {horse, cls} <- [
                    {"horse_red", "animate-float"},
                    {"horse_green", "animate-float-slow"},
                    {"horse_yellow", "animate-float"}
                  ]
                }
                src={"/images/assets/#{horse}.webp"}
                alt=""
                aria-hidden="true"
                width="174"
                height="224"
                class={["w-20 drop-shadow-lg sm:w-24", cls]}
              />
            </div>
          </div>
        </div>
      </div>
    </section>
    """
  end

  # -------------------------------------------------------------------- faq

  attr :faqs, :list, required: true

  defp faq_section(assigns) do
    ~H"""
    <section class="landing-band border-y-2 py-14 sm:py-20 2xl:py-28 border-cream-deep">
      <div class="mx-auto w-full max-w-3xl px-4 sm:px-6">
        <h2 class="text-center text-3xl font-extrabold tracking-tight sm:text-4xl text-ink">
          Câu hỏi thường gặp
        </h2>

        <div class="mt-8 space-y-3">
          <details :for={faq <- @faqs} class="toy-card group p-5">
            <summary class="flex list-none cursor-pointer items-center justify-between gap-4 text-lg font-extrabold [&::-webkit-details-marker]:hidden text-ink">
              {faq.q}
              <span
                class="shrink-0 text-2xl transition-transform group-open:rotate-45 text-ink-soft"
                aria-hidden="true"
              >
                +
              </span>
            </summary>
            <p class="mt-3 text-base leading-relaxed text-ink-soft">{faq.a}</p>
          </details>
        </div>
      </div>
    </section>
    """
  end

  # ------------------------------------------------------------ closing CTA

  attr :featured, :map, required: true

  defp closing_cta(assigns) do
    ~H"""
    <section class="mx-auto w-full max-w-4xl px-4 py-16 text-center sm:px-6 sm:py-24 2xl:py-32">
      <.toy_icon name="logo" class="mx-auto h-24 w-24" />
      <h2 class="mt-4 text-3xl font-extrabold tracking-tight sm:text-4xl text-ink">
        Tối nay, cả nhà chơi một ván nhé?
      </h2>
      <p class="mx-auto mt-3 max-w-xl text-lg text-ink-soft">
        Mở là chơi được liền — không đăng ký, không tải về, không mất tiền.
      </p>
      <.link navigate={@featured.path} class="toy-btn toy-btn--red mt-8 !text-xl">
        Bắt đầu với {@featured.name} <.toy_icon name="trophy" class="h-8 w-8" />
      </.link>
    </section>
    """
  end

  defp site_footer(assigns) do
    ~H"""
    <footer class="border-t-2 py-8 border-cream-deep">
      <div class={[
        "text-ink-soft",
        shell_class(),
        "flex flex-col items-center gap-2 text-center text-sm"
      ]}>
        <p class="flex items-center gap-2 font-extrabold text-ink">
          <.toy_icon name="logo" class="h-7 w-7" /> Bé vui học
        </p>
        <p>Trò chơi cờ bàn cho cả nhà, chơi chung trên một thiết bị.</p>
      </div>
    </footer>
    """
  end
end
